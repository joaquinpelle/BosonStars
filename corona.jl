
radial_bins(disk; nbins) = range(disk.inner_radius, disk.outer_radius, length=nbins+1)
radial_binsize(disk; nbins) = (disk.outer_radius-disk.inner_radius)/nbins

function ring_areas(bins, spacetime)
    radii = 0.5*(bins[1:end-1] + bins[2:end])
    Δr = bins[2:end] - bins[1:end-1]
    areas = zeros(length(radii))
    position = [0.0, 0.0, π/2, 0.0]
    g = zeros(4,4)
    for (i,r) in enumerate(radii)
        position[2] = r
        metric!(g, position, spacetime)
        areas[i] = 2π*sqrt(g[2,2]*g[4,4])*Δr[i]
    end
    return areas
end

function lorentz_factors(bins, spacetime, disk)
    radii = 0.5*(bins[1:end-1] + bins[2:end])
    γ = zeros(length(radii))
    position = [0.0, 0.0, π/2, 0.0]
    g = zeros(4,4)
    u = zeros(4)
    coords_top = coordinates_topology(spacetime)
    for (i,r) in enumerate(radii)
        position[2] = r
        metric!(g, position, spacetime)
        rest_frame_four_velocity!(u, position, g, spacetime, disk, coords_top)
        γ[i] = u[1] 
    end
    return γ
end

"""
Assuming all photons are emitted with unit initial energy in its frame
"""
function energies_quotients(data, spacetime::AbstractSpacetime, disk::AbstractAccretionDisk)
    coords_top = coordinates_topology(spacetime)
    nrays = size(data, 2)
    q = zeros(nrays)
    # Break the work into chunks. More chunks per thread has better load balancing but more overhead
    chunk_size = div(nrays, Threads.nthreads()*2)
    chunks = Iterators.partition(1:nrays, chunk_size)
    # Map over the chunks, creating an array of spawned tasks. Sync to wait for the tasks to finish.
    @sync map(chunks) do chunk
        Threads.@spawn begin
            g = zeros(4,4)
            u = zeros(4)
            for i in chunk
                @views begin 
                    position = data[1:4,i]
                    momentum = data[5:8,i]
                end
                metric!(g, position, spacetime)
                rest_frame_four_velocity!(u, position, g, spacetime, disk, coords_top)
                q[i] = -Skylight.scalar_product(u,momentum,g)
            end
        end
    end
    return q
end

function average_inside_radial_bins(q, radii, bins)
    # Initialize an array to hold the sum of `q` values in each bin
    qsums = zeros(eltype(q), length(bins)-1)
    # Initialize an array to hold the count of `q` values in each bin
    qcounts = zeros(Int, length(bins)-1)

    for (r, qvalue) in zip(radii, q)
        # Find the bin index for the current radii value
        bin_index = searchsortedlast(bins, r)

        # If the bin_index is valid (i.e., the radius value is not beyond the last bin edge)
        if bin_index > 0 && bin_index < length(bins)
            # Update the sum and count of `q` values for this bin
            qsums[bin_index] += qvalue
            qcounts[bin_index] += 1
        end
    end
    # Calculate the average `q` values for each bin
    averages = qsums ./ qcounts
    return averages
end